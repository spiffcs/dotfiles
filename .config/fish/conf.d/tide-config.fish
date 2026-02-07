# Tide prompt configuration (gruvbox-themed)
# Generated from `tide configure` — re-run and update this file to change.
# Only sets variables that aren't already defined, so `tide configure` on a
# live machine still wins until the next fresh bootstrap.

if not set -q tide_left_prompt_items
    # Prompt layout
    set -U tide_left_prompt_items os pwd git character
    set -U tide_left_prompt_frame_enabled false
    set -U tide_left_prompt_prefix
    set -U tide_left_prompt_suffix
    set -U tide_left_prompt_separator_diff_color ' '
    set -U tide_left_prompt_separator_same_color ' '

    set -U tide_right_prompt_items status cmd_duration context jobs direnv bun node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig time
    set -U tide_right_prompt_frame_enabled false
    set -U tide_right_prompt_prefix ' '
    set -U tide_right_prompt_suffix
    set -U tide_right_prompt_separator_diff_color ' '
    set -U tide_right_prompt_separator_same_color ' '

    # General prompt settings
    set -U tide_prompt_add_newline_before false
    set -U tide_prompt_color_frame_and_connection 665C54
    set -U tide_prompt_color_separator_same_color 928374
    set -U tide_prompt_icon_connection ' '
    set -U tide_prompt_min_cols 34
    set -U tide_prompt_pad_items false
    set -U tide_prompt_transient_enabled false

    # Character
    set -U tide_character_color B8BB26
    set -U tide_character_color_failure FB4934
    set -U tide_character_icon '❯'
    set -U tide_character_vi_icon_default '❮'
    set -U tide_character_vi_icon_replace '▶'
    set -U tide_character_vi_icon_visual V

    # OS
    set -U tide_os_bg_color normal
    set -U tide_os_color EBDBB2
    set -U tide_os_icon ''

    # PWD
    set -U tide_pwd_bg_color normal
    set -U tide_pwd_color_anchors D3869B
    set -U tide_pwd_color_dirs D3869B
    set -U tide_pwd_color_truncated_dirs 928374
    set -U tide_pwd_icon
    set -U tide_pwd_icon_home
    set -U tide_pwd_icon_unwritable ''
    set -U tide_pwd_markers .bzr .citc .git .hg .node-version .python-version .ruby-version .shorten_folder_marker .svn .terraform bun.lockb Cargo.toml composer.json CVS go.mod package.json build.zig

    # Git
    set -U tide_git_bg_color normal
    set -U tide_git_bg_color_unstable normal
    set -U tide_git_bg_color_urgent normal
    set -U tide_git_color_branch B8BB26
    set -U tide_git_color_conflicted FB4934
    set -U tide_git_color_dirty FABD2F
    set -U tide_git_color_operation FB4934
    set -U tide_git_color_staged FABD2F
    set -U tide_git_color_stash 8EC07C
    set -U tide_git_color_untracked 83A598
    set -U tide_git_color_upstream B8BB26
    set -U tide_git_icon ''
    set -U tide_git_truncation_length 24
    set -U tide_git_truncation_strategy

    # Status
    set -U tide_status_bg_color normal
    set -U tide_status_bg_color_failure normal
    set -U tide_status_color B8BB26
    set -U tide_status_color_failure FB4934
    set -U tide_status_icon '✔'
    set -U tide_status_icon_failure '✘'

    # Cmd duration
    set -U tide_cmd_duration_bg_color normal
    set -U tide_cmd_duration_color A89984
    set -U tide_cmd_duration_decimals 0
    set -U tide_cmd_duration_icon ''
    set -U tide_cmd_duration_threshold 3000

    # Context
    set -U tide_context_always_display false
    set -U tide_context_bg_color normal
    set -U tide_context_color_default FE8019
    set -U tide_context_color_root FB4934
    set -U tide_context_color_ssh D3869B
    set -U tide_context_hostname_parts 1

    # Jobs
    set -U tide_jobs_bg_color normal
    set -U tide_jobs_color 8EC07C
    set -U tide_jobs_icon ''
    set -U tide_jobs_number_threshold 1000

    # Time
    set -U tide_time_bg_color normal
    set -U tide_time_color 928374
    set -U tide_time_format '%T'

    # Vi mode
    set -U tide_vi_mode_bg_color_default normal
    set -U tide_vi_mode_bg_color_insert normal
    set -U tide_vi_mode_bg_color_replace normal
    set -U tide_vi_mode_bg_color_visual normal
    set -U tide_vi_mode_color_default A89984
    set -U tide_vi_mode_color_insert 83A598
    set -U tide_vi_mode_color_replace 8EC07C
    set -U tide_vi_mode_color_visual FE8019
    set -U tide_vi_mode_icon_default D
    set -U tide_vi_mode_icon_insert I
    set -U tide_vi_mode_icon_replace R
    set -U tide_vi_mode_icon_visual V

    # Shlvl
    set -U tide_shlvl_bg_color normal
    set -U tide_shlvl_color FE8019
    set -U tide_shlvl_icon ''
    set -U tide_shlvl_threshold 1

    # Node
    set -U tide_node_bg_color normal
    set -U tide_node_color B8BB26
    set -U tide_node_icon ''

    # Python
    set -U tide_python_bg_color normal
    set -U tide_python_color 83A598
    set -U tide_python_icon '󰌠'

    # Rust
    set -U tide_rustc_bg_color normal
    set -U tide_rustc_color FB4934
    set -U tide_rustc_icon ''

    # Go
    set -U tide_go_bg_color normal
    set -U tide_go_color 83A598
    set -U tide_go_icon ''

    # Java
    set -U tide_java_bg_color normal
    set -U tide_java_color ED8B00
    set -U tide_java_icon ''

    # Ruby
    set -U tide_ruby_bg_color normal
    set -U tide_ruby_color B31209
    set -U tide_ruby_icon ''

    # Docker
    set -U tide_docker_bg_color normal
    set -U tide_docker_color 458588
    set -U tide_docker_default_contexts default colima
    set -U tide_docker_icon ''

    # Kubectl
    set -U tide_kubectl_bg_color normal
    set -U tide_kubectl_color 326CE5
    set -U tide_kubectl_icon '󱃾'

    # Private mode
    set -U tide_private_mode_bg_color normal
    set -U tide_private_mode_color FFFFFF
    set -U tide_private_mode_icon '󰗹'

    # Direnv
    set -U tide_direnv_bg_color normal
    set -U tide_direnv_bg_color_denied normal
    set -U tide_direnv_color D7AF00
    set -U tide_direnv_color_denied FF0000
    set -U tide_direnv_icon '▼'

    # AWS
    set -U tide_aws_bg_color normal
    set -U tide_aws_color FF9900
    set -U tide_aws_icon ''

    # Bun
    set -U tide_bun_bg_color normal
    set -U tide_bun_color FBF0DF
    set -U tide_bun_icon '󰳓'

    # Terraform
    set -U tide_terraform_bg_color normal
    set -U tide_terraform_color 844FBA
    set -U tide_terraform_icon '󱁢'

    # Pulumi
    set -U tide_pulumi_bg_color normal
    set -U tide_pulumi_color F7BF2A
    set -U tide_pulumi_icon ''

    # PHP
    set -U tide_php_bg_color normal
    set -U tide_php_color 617CBE
    set -U tide_php_icon ''

    # Gcloud
    set -U tide_gcloud_bg_color normal
    set -U tide_gcloud_color 4285F4
    set -U tide_gcloud_icon '󰊭'

    # Nix shell
    set -U tide_nix_shell_bg_color normal
    set -U tide_nix_shell_color 7EBAE4
    set -U tide_nix_shell_icon ''

    # Crystal
    set -U tide_crystal_bg_color normal
    set -U tide_crystal_color FFFFFF
    set -U tide_crystal_icon ''

    # Elixir
    set -U tide_elixir_bg_color normal
    set -U tide_elixir_color 4E2A8E
    set -U tide_elixir_icon ''

    # Zig
    set -U tide_zig_bg_color normal
    set -U tide_zig_color F7A41D
    set -U tide_zig_icon ''

    # Distrobox
    set -U tide_distrobox_bg_color normal
    set -U tide_distrobox_color FF00FF
    set -U tide_distrobox_icon '󰆧'

    # Toolbox
    set -U tide_toolbox_bg_color normal
    set -U tide_toolbox_color 613583
    set -U tide_toolbox_icon ''
end
