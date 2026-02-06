function fish_prompt
    set_color blue
    echo -n (prompt_pwd)
    set_color yellow
    echo -n " "(fish_vcs_prompt)  # git branch/status
    set_color normal
    echo -n "> "
end
