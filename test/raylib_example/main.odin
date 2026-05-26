package raylib_test

import "core:fmt"
import ray "vendor:raylib"

import um "../../src"

rlDrawPlane :: proc "c" (params, result: [^]um.StackSlot) {
    center_pos := cast(^ray.Vector3)um.GetParam(params, 0)
    size := cast(^ray.Vector2)um.GetParam(params, 1)
    color := cast(^ray.Color)um.GetParam(params, 2)

    ray.DrawPlane(center_pos^, size^, color^)
}

rlDrawCube :: proc "c" (params, result: [^]um.StackSlot) {

    position := cast(^ray.Vector3)um.GetParam(params, 0)
    width  := cast(f32) um.GetParam(params, 1).realVal
    height := cast(f32) um.GetParam(params, 2).realVal
    length := cast(f32) um.GetParam(params, 3).realVal
    color := cast(^ray.Color)um.GetParam(params, 4)

    ray.DrawCube(position^, width, height, length, color^)

}

main :: proc() {

    umkaInitBodies, umkaDrawBodies: um.FuncContext
    umka := um.Alloc()
    defer um.Free(umka)
    umka_ok := um.Init(umka, "raylib_example/3dcam.um")

    if umka_ok {

        um.AddFunc(umka, "drawPlane", rlDrawPlane)
        um.AddFunc(umka, "drawCube", rlDrawCube)

        um.AddModule(umka, "rl.um", `
type Vector2* = struct {x, y: real32}
type Vector3* = struct {x, y, z: real32}
type Color*   = struct {r, g, b, a: uint8}
fn drawPlane*(centerPos: Vector3, size: Vector2, color: Color)
fn drawCube*(position: Vector3, width,height,length:real, color: Color)
        `)

        umka_ok = um.Compile(umka)

    }

    if (umka_ok) {
        fmt.println("Umka initialized\n")
        um.GetFunc(umka, nil, "initBodies", &umkaInitBodies)
        um.GetFunc(umka, nil, "drawBodies", &umkaDrawBodies)
    }
    else {
        error := um.GetError(umka)
        fmt.printfln("Umka error %s (%d, %d): %s\n", error.fileName, error.line, error.pos, error.msg)
    }

    screen_width, screen_height :: 800, 450

    ray.InitWindow(screen_width, screen_height, "raylib [core] example - 3d camera first person")
    defer ray.CloseWindow()

    camera: ray.Camera
    camera.position = {4.0, 2.0, 4.0}
    camera.target = {0.0, 1.8, 0.0}
    camera.up = {0.0, 1.0, 0.0}
    camera.fovy = 60

    if umka_ok {
        umka_ok = um.Call(umka, &umkaInitBodies) == 0
    }
    else {
        error := um.GetError(umka)
        fmt.printfln("Umka runtime error %s (%d, %d): %s\n", error.fileName, error.line, error.pos, error.msg)
    }
    

    ray.SetTargetFPS(60)

    exit_code:i32 = 0

    if umka_ok {

        for !ray.WindowShouldClose() {
            ray.UpdateCamera(&camera, .FIRST_PERSON)

            ray.BeginDrawing()
                ray.ClearBackground({190, 190, 255, 255})

                ray.BeginMode3D(camera)

                exit_code = um.Call(umka, &umkaDrawBodies)

                if !um.Alive(umka) {
                    if exit_code != 0 {

                        error := um.GetError(umka)
                        fmt.printfln("Umka runtime error %s (%d, %d): %s\n", error.fileName, error.line, error.msg)

                    }
                    break
                }

                ray.EndMode3D()

                ray.DrawRectangle(10, 10, 220, 70, ray.Fade(ray.SKYBLUE, 0.5))
                ray.DrawRectangleLines(10, 10, 220, 70, ray.BLUE)

                ray.DrawText("First person camera default controls:", 20, 20, 10, ray.BLACK)
                ray.DrawText("- Move with keys: W, A, S, D", 40, 40, 10, ray.DARKGRAY)
                ray.DrawText("- Mouse move to look around", 40, 60, 10, ray.DARKGRAY)
            ray.EndDrawing()
        }

    }

}
