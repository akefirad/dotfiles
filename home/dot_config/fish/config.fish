set SDKMAN_DIR (brew --prefix sdkman-cli)/libexec

# Add SDKMAN candidates to PATH
for candidate in (find -L "$SDKMAN_DIR/candidates" -type d -path '*/current/bin')
    fish_add_path $candidate
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

eval "$(starship init fish)"
