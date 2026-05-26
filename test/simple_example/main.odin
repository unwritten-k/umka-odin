package test_1

import "base:runtime"
import "core:fmt"
import um "../../src"

print_fn :: proc "c" (params, result: [^]um.StackSlot) {
    context = runtime.default_context()

    bytes := cast([^]byte) um.GetParam(params, 0).ptrVal
    str := cstring(bytes)

    num := um.GetParam(params, 1).intVal

    fmt.println("Given string: '", str, "'; given number: ", num, sep="")
}

main :: proc() {
    fmt.println("Note: run this from the test directory")
    
    umka := um.Alloc()
    defer if um.Alive(umka) do um.Free(umka)
    umka_ok := um.Init(umka, "simple_example/test.um")

    if !umka_ok {
        fmt.eprintln("Could not initialize Umka! Error:", um.GetError(umka))
    }
    else {
        fmt.eprintln("Initialized Umka succesfully! Alive:",um.Alive(umka))
    }

    um.AddFunc(umka, "print", print_fn)
    um.AddModule(umka, "module.um", 
        "fn print*(text: str, num: int)\n"
    )

    umka_ok = um.Compile(umka)
    if !umka_ok {
        fmt.eprintln("Could not compile Umka! Error:", um.GetError(umka))
    }

    print_stmt_context: um.FuncContext
    umka_ok = um.GetFunc(umka, nil, "print_stmt", &print_stmt_context)
    if !umka_ok {
        fmt.eprintln("Could not get print_stmt function! Error:", um.GetError(umka))
    }

    if err_code := um.Call(umka, &print_stmt_context); err_code != 0 {
        fmt.eprintln("Could not call print_stmt function! Error code:", err_code)
    }
}
