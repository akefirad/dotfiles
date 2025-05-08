function nvm
    set --local nvm_dir $HOME/.nvm
    env NVM_DIR=$nvm_dir bash -c "source $nvm_dir/nvm.sh; nvm $argv"
end
