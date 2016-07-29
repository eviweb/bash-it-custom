safe_append_prompt_command()
{
    if [[ -n $1 ]] && [[ -n $PROMPT_COMMAND ]]; then
        case $PROMPT_COMMAND in
            $1) ;;
            *) PROMPT_COMMAND="$1;$PROMPT_COMMAND";;
        esac
    elif [[ -n $1 ]]; then
        PROMPT_COMMAND="$1"
    fi
}

disable_sdkman_gvm_alias()
{
    local config="${HOME}/.sdkman/etc/config"
    [ -f  "${config}" ] && \
        sed -e 's/sdkman_disable_gvm_alias=false/sdkman_disable_gvm_alias=true/g' \
            -i "${config}"
}

disable_sdkman_gvm_alias