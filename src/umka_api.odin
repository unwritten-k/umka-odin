package umka_lang

UMKA_SHARED :: #config(UMKA_SHARED, false)

when UMKA_SHARED {
    when ODIN_OS == .Linux {
        foreign import lib "linux/libumka.so"
    }
    else when ODIN_OS == .Windows {
        foreign import lib "windows/libumka.dll"
    }
    else {
        foreign import lib "system:umka"
    }
}
else {
    when ODIN_OS == .Linux {
        foreign import lib "linux/libumka_static_linux.a"
    }
    else when ODIN_OS == .Windows {
        foreign import lib "windows/libumka_static.lib"
    }
    else {
        foreign import lib "system:umka"
    }
}

tagUmka :: struct {}
Umka :: tagUmka

StackSlot :: struct #raw_union {
    intVal      : i64,    
    uintVal     : u64,    
    ptrVal      : rawptr, 
    realVal     : f64,    
    real32Val   : f32     // Not used in result slots
}

FuncContext :: struct {
    entryOffset: i64,
    params: ^StackSlot,
    result: ^StackSlot,
}

ExternFunc :: #type proc "c" (params, result: ^StackSlot)

HookEvent :: enum {
    UMKA_HOOK_CALL,
    UMKA_HOOK_RETURN,

    _,
}

HookFunc :: #type proc "c" (fileName, funcName:cstring, line:i32)

tagType :: struct {}
Type :: tagType

DynArray :: struct ($T: typeid)  {
    type: ^Type, // should not be changed
    itemSize: i64,
    data: T
}

tagMapNode :: struct {}
Map :: struct {
    type: ^Type,
    root: ^tagMapNode
}

Any :: struct {

    struct #raw_union {
        data: rawptr,
        self: rawptr
    },

    struct #raw_union {
        type: ^Type,
        self_type: ^Type,
    }
}

Closure :: struct {
    entryOffset: i64,
    upvalue: Any
}


Error :: struct {
    fileName: cstring,
    fnName: cstring,
    line, pos, code: i32,
    msg: cstring
}

WarningCallback :: #type proc "c" (warning: ^Error)

// function typedefs
fn_UmkaAlloc           :: #type proc "c" () -> ^Umka
fn_UmkaInit            :: #type proc "c" (umka: ^Umka, fileName, sourceString: cstring, stackSize: i32, reserver: rawptr, argc: i32, argv: [^]^byte, fileSystemEnabled, implLibsEnabled: bool, warning: WarningCallback) -> bool
fn_UmkaCompile         :: #type proc "c" (umka: ^Umka,) -> bool
fn_UmkaRun             :: #type proc "c" (umka: ^Umka,) -> i32
fn_UmkaCall            :: #type proc "c" (umka: ^Umka, fn: ^FuncContext) -> i32
fn_UmkaFree            :: #type proc "c" (umka: ^Umka,)
fn_UmkaGetError        :: #type proc "c" (umka: ^Umka,) -> ^Error
fn_UmkaAlive           :: #type proc "c" (umka: ^Umka,) -> bool
fn_UmkaAsm             :: #type proc "c" (umka: ^Umka,) -> [^]byte
fn_UmkaAddModule       :: #type proc "c" (umka: ^Umka, fileName, sourceString: cstring) -> bool
fn_UmkaAddFunc         :: #type proc "c" (umka: ^Umka, name: cstring, func: ExternFunc) -> bool
fn_UmkaGetFunc         :: #type proc "c" (umka: ^Umka, moduleName, fnName: cstring, fn: ^FuncContext) -> bool
fn_UmkaGetCallStack    :: #type proc "c" (umka: ^Umka, depth: i32, nameSize: i32, offset: ^i32, fileName, fnName: [^]byte, line:^i32) -> bool
fn_UmkaSetHook         :: #type proc "c" (umka: ^Umka, event: HookEvent, hook: HookFunc)
fn_UmkaAllocData       :: #type proc "c" (umka: ^Umka, size: i32, onFree: ExternFunc) -> rawptr
fn_UmkaIncRef          :: #type proc "c" (umka: ^Umka, ptr: rawptr)
fn_UmkaDecRef          :: #type proc "c" (umka: ^Umka, ptr: rawptr)
fn_UmkaGetMapItem      :: #type proc "c" (umka: ^Umka, map_: ^Map, key: StackSlot) -> rawptr
fn_UmkaMakeStr         :: #type proc "c" (umka: ^Umka, str: cstring) -> [^]byte
fn_UmkaGetStrLen       :: #type proc "c" (str: cstring) -> i32
fn_UmkaMakeDynArray    :: #type proc "c" (umka: ^Umka, array: rawptr, type: ^Type, len: i32)
fn_UmkaGetDynArrayLen  :: #type proc "c" (array: rawptr)
fn_UmkaGetVersion      :: #type proc "c" () -> i32
fn_UmkaGetMemUsage     :: #type proc "c" (umka: ^Umka,) -> i64
fn_UmkaMakeFuncContext :: #type proc "c" (umka: ^Umka, closureType: ^Type, entryOffset:i32, fn: ^FuncContext)
fn_UmkaGetParam        :: #type proc "c" (params: [^]StackSlot, index: i32) -> ^StackSlot
fn_UmkaGetUpValue      :: #type proc "c" (params: [^]StackSlot) -> ^Any
fn_UmkaGetResult       :: #type proc "c" (params, result: [^]StackSlot) -> ^StackSlot
fn_UmkaGetGetMetadata  :: #type proc "c" (umka: ^Umka,) -> rawptr
fn_UmkaSetMedata       :: #type proc "c" (umka: ^Umka, metadata: rawptr)
fn_UmkaMakeStruct      :: #type proc "c" (umka: ^Umka, type: ^Type)
fn_UmkaGetBaseType     :: #type proc "c" (type: ^Type) -> ^Type
fn_UmkaGetParamType    :: #type proc "c" (params: [^]StackSlot, index: i32) -> ^Type
fn_UmkaGetResultType   :: #type proc "c" (params, result: [^]StackSlot) -> ^Type
fn_UmkaGetFieldType    :: #type proc "c" (structType: ^Type, fieldName: cstring) -> ^Type
fn_UmkaGetMapKeyType   :: #type proc "c" (mapType: ^Type) -> ^Type
fn_UmkaGetMapItemType  :: #type proc "c" (mapType: ^Type) -> ^Type
fn_UmkaAddClosure      :: #type proc "c" (umka: ^Umka, name: cstring, func: ExternFunc, upvalue: rawptr)

API :: struct {
    umkaAlloc           : fn_UmkaAlloc,
    umkaInit            : fn_UmkaInit,
    umkaCompile         : fn_UmkaCompile,
    umkaRun             : fn_UmkaRun,
    umkaCall            : fn_UmkaRun,
    umkaFree            : fn_UmkaFree,
    umkaGetError        : fn_UmkaGetError,
    umkaAlive           : fn_UmkaAlive,
    umkaAsm             : fn_UmkaAsm,
    umkaAddModule       : fn_UmkaAddModule,
    umkaAddFunc         : fn_UmkaAddFunc,
    umkaGetFunc         : fn_UmkaGetFunc,
    umkaGetCallStack    : fn_UmkaGetCallStack,
    umkaSetHook         : fn_UmkaSetHook,
    umkaAllocData       : fn_UmkaAllocData,
    umkaIncRef          : fn_UmkaIncRef,
    umkaDecRef          : fn_UmkaDecRef,
    umkaGetMapItem      : fn_UmkaGetMapItem,
    umkaMakeStr         : fn_UmkaMakeStr,
    umkaGetStrLen       : fn_UmkaGetStrLen,
    umkaMakeDynArray    : fn_UmkaMakeDynArray,
    umkaGetDynArrayLen  : fn_UmkaGetDynArrayLen,
    umkaGetVersion      : fn_UmkaGetVersion,
    umkaGetMemUsage     : fn_UmkaGetMemUsage,
    umkaMakeFuncContext : fn_UmkaMakeFuncContext,
    umkaGetParam        : fn_UmkaGetParam,
    umkaGetUpValue      : fn_UmkaGetUpValue,
    umkaGetResult       : fn_UmkaGetResult,
    umkaGetMetadata     : fn_UmkaGetGetMetadata,
    umkaSetMetadata     : fn_UmkaSetMedata,
    umkaMakeStruct      : fn_UmkaMakeStruct,
    umkaGetBaseType     : fn_UmkaGetBaseType,
    umkaGetParamType    : fn_UmkaGetParamType,
    umkaGetResultType   : fn_UmkaGetResultType,
    umkaGetFieldType    : fn_UmkaGetFieldType,
    umkaGetMapKeyType   : fn_UmkaGetMapKeyType,
    umkaGetMapItemType  : fn_UmkaGetMapItemType,
    umkaAddClosure      : fn_UmkaAddClosure
} // UmkaAPI
