;; nbt parser by FetchBot (Ian Senne)
(module
  (import "env" "push_byte" (func $push_byte (param i32)))
  (import "env" "push_short" (func $push_short (param i32)))
  (import "env" "push_int" (func $push_int (param i32)))
  (import "env" "push_long" (func $push_long (param i64)))
  (import "env" "push_float" (func $push_float (param f32)))
  (import "env" "push_double" (func $push_double (param f64)))
  (import "env" "push_byte_array" (func $push_byte_array (param i32 i32)))
  (import "env" "push_string" (func $push_string (param i32 i32)))
  (import "env" "push_list" (func $push_list (param i32)))
  (import "env" "push_compound" (func $push_compound (param i32 i32 i32)))
  (import "env" "push_int_array" (func $push_int_array (param i32 i32)))
  (import "env" "push_long_array" (func $push_long_array (param i32 i32)))
  (memory $mem 0)
  (export "memory" (memory $mem))
  (global $memory (mut i32) (i32.const 0))
  (global $index (mut i32) (i32.const 0))
  (global $root (mut i32) (i32.const 0))
  (func $inc
    (global.get $index)
    i32.const 1
    i32.add
    (global.set $index)
  )
  (func $incn (param $n i32)
    (global.get $index)
    local.get $n
    i32.add
    (global.set $index)
  )
  (func $parse_tag_end (result i32)
    i32.const 0
  )
  (func $parse_tag_byte (result i32)
    global.get $index
    i32.load8_s
    call $push_byte
    call $inc
    i32.const 1
  )
  (func $parse_tag_short (result i32)
    global.get $index
    i32.load16_s
    call $push_short
    i32.const 2
    call $incn
    i32.const 2
  )
  (func $parse_tag_int (result i32)
    global.get $index
    i32.load
    call $push_int
    i32.const 4
    call $incn
    i32.const 3
  )
  (func $parse_tag_long (result i32)
    global.get $index
    i64.load
    call $push_long
    i32.const 8
    call $incn
    i32.const 4
  )
  (func $parse_tag_float (result i32)
    global.get $index
    f32.load
    call $push_float
    i32.const 4
    call $incn
    i32.const 5
  )
  (func $parse_tag_double (result i32)
    global.get $index
    f64.load
    call $push_double
    i32.const 8
    call $incn
    i32.const 6
  )
  (func $parse_tag_byte_array (result i32)
    (local $length i32)
    global.get $index
    i32.load
    local.set $length
    global.get $index
    i32.const 4
    i32.add
    global.set $index
    global.get $index
    local.get $length
    call $push_byte_array
    local.get $length
    call $incn
    i32.const 7
  )
  (func $parse_tag_string (result i32)
    (local $length i32)
    (local $string_start i32)
    global.get $index
    i32.load16_u
    local.set $length
    global.get $index
    i32.const 2
    i32.add
    local.set $string_start
    local.get $string_start
    local.get $length
    call $push_string
    local.get $length
    i32.const 2
    i32.add
    call $incn
    i32.const 8
  )
  (func $parse_tag_list (result i32)
    (local $type i32)
    (local $count i32)
    (local $count2 i32)
    global.get $index
    i32.load8_s
    local.set $type
    global.get $index
    i32.const 1
    i32.add
    i32.load
    local.set $count2
    local.get $count2
    local.set $count
    global.get $index
    i32.const 5
    i32.add
    global.set $index
    local.get $count
    i32.eqz
    if
      i32.const 0
      call $push_list
      i32.const 9
      return
    end
    loop $loop
      local.get $count
      i32.const 1
      i32.sub
      local.set $count
      local.get $type
      call_indirect $parse_table (result i32)
      drop
      local.get $count
      i32.const 0
      i32.ne
      br_if $loop
    end
    local.get $count2
    call $push_list
    i32.const 9
  )
  (func $parse_tag_compound (result i32)
    (local $var0 i32)
    (local $count i32)
    (i32.eqz (global.get $root))
    if (result i32 i32)
        i32.const 0
        i32.const 0
    else
        global.get $index
        i32.load16_u
        local.set $var0
        global.get $index
        i32.const 2
        i32.add
        local.get $var0
        i32.add
        global.set $index
        i32.const 0
        global.set $root
        i32.const 0
        i32.const 0
    end
    loop $loop
      global.get $index
      i32.load8_s
      local.tee $var0
      call $inc
      i32.const 0
      i32.ne
      if
        call $parse_tag_string
        drop
        local.get $var0
        call_indirect $parse_table (result i32)
        drop
        local.get $count
        i32.const 1
        i32.add
        local.set $count
        br $loop
      else
      end
    end
    local.get $count
    call $push_compound
    i32.const 10
  )
  (func $parse_tag_int_array (result i32)
    (local $length i32)
    global.get $index
    i32.load
    local.set $length
    global.get $index
    i32.const 4
    i32.add
    global.set $index
    global.get $index
    local.get $length
    call $push_int_array
    local.get $length
    i32.const 4
    i32.mul
    call $incn
    i32.const 11
  )
  (func $parse_tag_long_array (result i32)
    (local $length i32)
    global.get $index
    i32.load
    local.set $length
    global.get $index
    i32.const 4
    i32.add
    global.set $index
    global.get $index
    local.get $length
    call $push_long_array
    local.get $length
    i32.const 8
    i32.mul
    call $incn
    i32.const 12
  )
  (func $get (result i32)
    global.get $index
    i32.load8_s
  )
  (func $parse (param $root i32) (result i32) (local $idx i32)
    (global.set $root (local.get $root))
    call $get
    call $inc
    call_indirect $parse_table (result i32)
  )
  (export "parse" (func $parse))
  (table $parse_table 13 funcref)
  (elem (i32.const 0) $parse_tag_end)
  (elem (i32.const 1) $parse_tag_byte)
  (elem (i32.const 2) $parse_tag_short)
  (elem (i32.const 3) $parse_tag_int)
  (elem (i32.const 4) $parse_tag_long)
  (elem (i32.const 5) $parse_tag_float)
  (elem (i32.const 6) $parse_tag_double)
  (elem (i32.const 7) $parse_tag_byte_array)
  (elem (i32.const 8) $parse_tag_string)
  (elem (i32.const 9) $parse_tag_list)
  (elem (i32.const 10) $parse_tag_compound)
  (elem (i32.const 11) $parse_tag_int_array)
  (elem (i32.const 12) $parse_tag_long_array)
)