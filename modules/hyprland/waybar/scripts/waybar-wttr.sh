#!/usr/bin/env bash

DEBUG=false
if [[ "$1" == "--debug" ]]; then
    DEBUG=true
fi

debug() {
    if [[ "$DEBUG" == true ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

declare -A WEATHER_CODES=(
    ["113"]="☀️ "
    ["116"]="⛅ "
    ["119"]="☁️ "
    ["122"]="☁️ "
    ["143"]="☁️ "
    ["176"]="🌧️"
    ["179"]="🌧️"
    ["182"]="🌧️"
    ["185"]="🌧️"
    ["200"]="⛈️ "
    ["227"]="🌨️"
    ["230"]="🌨️"
    ["248"]="☁️ "
    ["260"]="☁️ "
    ["263"]="🌧️"
    ["266"]="🌧️"
    ["281"]="🌧️"
    ["284"]="🌧️"
    ["293"]="🌧️"
    ["296"]="🌧️"
    ["299"]="🌧️"
    ["302"]="🌧️"
    ["305"]="🌧️"
    ["308"]="🌧️"
    ["311"]="🌧️"
    ["314"]="🌧️"
    ["317"]="🌧️"
    ["320"]="🌨️"
    ["323"]="🌨️"
    ["326"]="🌨️"
    ["329"]="❄️ "
    ["332"]="❄️ "
    ["335"]="❄️ "
    ["338"]="❄️ "
    ["350"]="🌧️"
    ["353"]="🌧️"
    ["356"]="🌧️"
    ["359"]="🌧️"
    ["362"]="🌧️"
    ["365"]="🌧️"
    ["368"]="🌧️"
    ["371"]="❄️"
    ["374"]="🌨️"
    ["377"]="🌨️"
    ["386"]="🌨️"
    ["389"]="🌨️"
    ["392"]="🌧️"
    ["395"]="❄️ "
)

temp_unit="F"
speed_unit="Miles"

MAX_RETRIES=3
RETRY_DELAY=2

fetch_weather() {
    local attempt=1
    local weather=""
    local curl_exit_code
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        debug "Fetching weather data from wttr.in (attempt $attempt/$MAX_RETRIES)..."
        weather=$(curl -sf --connect-timeout 10 --max-time 30 "https://wttr.in/?format=j1" 2>/dev/null)
        curl_exit_code=$?
        
        if [[ $curl_exit_code -eq 0 && -n "$weather" ]]; then
            debug "Weather data received, length: ${#weather} bytes"
            echo "$weather"
            return 0
        fi
        
        debug "curl exit code: $curl_exit_code (35=SSL error, 92=HTTP/2 stream error)"
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            debug "Retrying in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
            RETRY_DELAY=$((RETRY_DELAY * 2))
        fi
        
        ((attempt++))
    done
    
    debug "All $MAX_RETRIES attempts failed, exiting"
    return 1
}

weather=$(fetch_weather)
if [[ -z "$weather" ]]; then
    exit
fi

get_weather_icon() {
    local code="$1"
    echo "${WEATHER_CODES[$code]:-☁️ }"
}

format_time() {
    local time="$1"
    time="${time%00}"
    printf "%02d" "$time"
}

format_temp() {
    local temp="$1"
    printf "%-3s" "${temp}°${temp_unit}"
}

format_chances() {
    local hour_data="$1"
    local conditions=()
    
    declare -A chances=(
        ["chanceoffog"]="Fog"
        ["chanceoffrost"]="Frost"
        ["chanceofovercast"]="Overcast"
        ["chanceofrain"]="Rain"
        ["chanceofsnow"]="Snow"
        ["chanceofsunshine"]="Sunshine"
        ["chanceofthunder"]="Thunder"
        ["chanceofwindy"]="Wind"
    )
    
    for event in "${!chances[@]}"; do
        local value
        value=$(echo "$hour_data" | jq -r ".$event")
        if [[ "$value" -gt 0 ]]; then
            conditions+=("${chances[$event]} ${value}%")
        fi
    done
    
    local IFS=", "
    echo "${conditions[*]}"
}

debug "Parsing current conditions..."
current_code=$(echo "$weather" | jq -r '.current_condition[0].weatherCode')
current_feels_like=$(echo "$weather" | jq -r ".current_condition[0].FeelsLike${temp_unit}")
current_temp=$(echo "$weather" | jq -r ".current_condition[0].temp_${temp_unit}")
current_desc=$(echo "$weather" | jq -r '.current_condition[0].weatherDesc[0].value')
current_wind=$(echo "$weather" | jq -r ".current_condition[0].windspeed${speed_unit}")
current_humidity=$(echo "$weather" | jq -r '.current_condition[0].humidity')

debug "Current: code=$current_code, feels_like=$current_feels_like, temp=$current_temp"
debug "Current: desc=$current_desc, wind=$current_wind, humidity=$current_humidity"

text=" $(get_weather_icon "$current_code") ${current_feels_like}°${temp_unit}"

tooltip="<b>${current_desc} ${current_temp}°</b>\n"
tooltip+="Feels like: ${current_feels_like}°\n"
tooltip+="Wind: ${current_wind}${speed_unit}\n"
tooltip+="Humidity: ${current_humidity}%\n"

current_hour=$(date +%-H)
debug "Current hour: $current_hour"

num_days=$(echo "$weather" | jq '.weather | length')
debug "Processing $num_days days of forecast..."
for ((i=0; i<num_days; i++)); do
    day=$(echo "$weather" | jq ".weather[$i]")
    date_str=$(echo "$day" | jq -r '.date')
    max_temp=$(echo "$day" | jq -r ".maxtemp${temp_unit}")
    min_temp=$(echo "$day" | jq -r ".mintemp${temp_unit}")
    sunrise=$(echo "$day" | jq -r '.astronomy[0].sunrise')
    sunset=$(echo "$day" | jq -r '.astronomy[0].sunset')
    
    tooltip+="\n<b>"
    if [[ $i -eq 0 ]]; then
        tooltip+="Today, "
    elif [[ $i -eq 1 ]]; then
        tooltip+="Tomorrow, "
    fi
    tooltip+="${date_str}</b>\n"
    tooltip+="⬆️ ${max_temp}° ⬇️ ${min_temp}° "
    tooltip+="🌅 ${sunrise} 🌇 ${sunset}\n"
    
    num_hours=$(echo "$day" | jq '.hourly | length')
    for ((h=0; h<num_hours; h++)); do
        hour_data=$(echo "$day" | jq ".hourly[$h]")
        hour_time=$(echo "$hour_data" | jq -r '.time')
        formatted_time=$(format_time "$hour_time")
        
        if [[ $i -eq 0 ]]; then
            if [[ 10#$formatted_time -lt $((current_hour - 2)) ]]; then
                continue
            fi
        fi
        
        hour_code=$(echo "$hour_data" | jq -r '.weatherCode')
        hour_feels_like=$(echo "$hour_data" | jq -r ".FeelsLike${temp_unit}")
        hour_desc=$(echo "$hour_data" | jq -r '.weatherDesc[0].value')
        hour_chances=$(format_chances "$hour_data")
        
        tooltip+="${formatted_time} $(get_weather_icon "$hour_code") $(format_temp "$hour_feels_like") ${hour_desc}, ${hour_chances}\n"
    done
done

tooltip="${tooltip%\\n}"

debug "Text output: $text"
debug "Generating final JSON output..."
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
debug "Done"
