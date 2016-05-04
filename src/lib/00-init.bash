disable_sdkman_gvm_alias()
{
    local config="${HOME}/.sdkman/etc/config"
    [ -f  "${config}" ] && \
        sed -e 's/sdkman_disable_gvm_alias=false/sdkman_disable_gvm_alias=true/g' \
            -i "${config}"
}

disable_sdkman_gvm_alias