# Gruvbox Dark Hard color theme for fish and tide
#
# Palette reference:
#   bg0_h  1d2021  bg1  3c3836  bg2  504945  bg3  665c54
#   fg1    ebdbb2  fg4  a89984  gray 928374
#   red    fb4934  green  b8bb26  yellow fabd2f
#   blue   83a598  purple d3869b  aqua   8ec07c
#   orange fe8019  dblue  458588

# ── Fish syntax highlighting ──────────────────────────────────────
set -g fish_color_autosuggestion 928374
set -g fish_color_cancel --reverse
set -g fish_color_command B8BB26
set -g fish_color_comment 928374
set -g fish_color_cwd B8BB26
set -g fish_color_cwd_root FB4934
set -g fish_color_end FE8019
set -g fish_color_error FB4934
set -g fish_color_escape 8EC07C
set -g fish_color_history_current --bold
set -g fish_color_host normal
set -g fish_color_host_remote FABD2F
set -g fish_color_keyword B8BB26
set -g fish_color_match 83A598
set -g fish_color_normal EBDBB2
set -g fish_color_operator 8EC07C
set -g fish_color_option 83A598
set -g fish_color_param EBDBB2
set -g fish_color_quote FABD2F
set -g fish_color_redirection D3869B
set -g fish_color_search_match FABD2F --background=3C3836
set -g fish_color_selection EBDBB2 --bold --background=504945
set -g fish_color_status FB4934
set -g fish_color_user B8BB26
set -g fish_color_valid_path --underline

# ── Fish pager ────────────────────────────────────────────────────
set -g fish_pager_color_completion EBDBB2
set -g fish_pager_color_description A89984
set -g fish_pager_color_prefix B8BB26 --bold --underline
set -g fish_pager_color_progress EBDBB2 --background=458588
set -g fish_pager_color_selected_background --background=504945

# ── Tide prompt ───────────────────────────────────────────────────
set -g tide_character_color B8BB26
set -g tide_character_color_failure FB4934
set -g tide_cmd_duration_color A89984
set -g tide_context_color_default FE8019
set -g tide_context_color_root FB4934
set -g tide_context_color_ssh D3869B
set -g tide_docker_color 458588
set -g tide_git_color_branch B8BB26
set -g tide_git_color_conflicted FB4934
set -g tide_git_color_dirty FABD2F
set -g tide_git_color_operation FB4934
set -g tide_git_color_staged FABD2F
set -g tide_git_color_stash 8EC07C
set -g tide_git_color_untracked 83A598
set -g tide_git_color_upstream B8BB26
set -g tide_go_color 83A598
set -g tide_jobs_color 8EC07C
set -g tide_node_color B8BB26
set -g tide_os_color EBDBB2
set -g tide_prompt_color_frame_and_connection 665C54
set -g tide_prompt_color_separator_same_color 928374
set -g tide_python_color 83A598
set -g tide_rustc_color FB4934
set -g tide_shlvl_color FE8019
set -g tide_status_color B8BB26
set -g tide_status_color_failure FB4934
set -g tide_time_color 928374
set -g tide_vi_mode_color_default A89984
set -g tide_vi_mode_color_insert 83A598
set -g tide_vi_mode_color_replace 8EC07C
set -g tide_pwd_color_anchors D3869B
set -g tide_pwd_color_dirs D3869B
set -g tide_pwd_color_truncated_dirs 928374
set -g tide_vi_mode_color_visual FE8019
