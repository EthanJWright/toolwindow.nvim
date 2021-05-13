if exists("g:loaded_toolwindow")
    finish
endif

lua require("toolwindow.validate").create_commands()

let g:loaded_toolwindow = 1
