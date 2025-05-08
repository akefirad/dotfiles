function gradlew
    set dir (pwd)

    while test "$dir" != "/"
        if test -x "$dir/gradlew"
            "$dir/gradlew" $argv
            return $status
        end
        set dir (dirname "$dir")
    end

    if type -q gradle
        command gradle $argv
    else
        echo "No gradle wrapper found and 'gradle' is not installed." >&2
        return 1
    end
end
