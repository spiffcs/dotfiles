function fish_right_prompt
    set -l last_status $status
    set -l duration $CMD_DURATION

    set -l parts

    if test $last_status -ne 0
        set -a parts (set_color red)"[$last_status]"(set_color normal)
    end

    if test $duration -ge 5000
        set -l secs (math --scale=1 $duration / 1000)
        set -a parts (set_color yellow)"$secs"s(set_color normal)
    end

    string join " " -- $parts
end
