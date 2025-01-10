function cat
    # Check if bat is installed
    if command -v bat > /dev/null
        # Use bat if it's available
        command bat "$argv"
    else
        # Fallback to cat if bat is not installed
        command cat "$argv"
    end
end
