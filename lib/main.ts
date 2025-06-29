import wasm from "./nbt.wat";
type NbtValue =
  | {
      type: 0;
    }
  | {
      type: 1;
      value: number;
    }
  | {
      type: 2;
      value: number;
    }
  | {
      type: 3;
      value: number;
    }
  | {
      type: 4;
      value: bigint;
    }
  | {
      type: 5;
      value: number;
    }
  | {
      type: 6;
      value: number;
    }
  | {
      type: 7;
      value: Int8Array;
    }
  | {
      type: 8;
      value: string;
    }
  | {
      type: 9;
      values: NbtValue[];
    }
  | {
      type: 10;
      name?: string;
      value: Record<string, NbtValue>;
    }
  | {
      type: 11;
      value: Int32Array;
    }
  | {
      type: 12;
      value: BigInt64Array;
    };
let value_stack: NbtValue[] = [];
let _memory: Uint8Array;
const bytes = wasm as unknown as Uint8Array;
const td = new TextDecoder();
let use_le: boolean = true;
const module = new WebAssembly.Instance(new WebAssembly.Module(bytes.buffer), {
  env: {
    push_byte: (value: number) => {
      value_stack.push({ type: 1, value });
    },
    push_short: (value: number) => {
      value_stack.push({ type: 2, value });
    },
    push_int: (value: number) => {
      value_stack.push({ type: 3, value });
    },
    push_long: (value: bigint) => {
      value_stack.push({ type: 4, value });
    },
    push_float: (value: number) => {
      value_stack.push({ type: 5, value });
    },
    push_double: (value: number) => {
      value_stack.push({ type: 6, value });
    },
    push_byte_array: (offset: number, length: number) => {
      const arr = new Int8Array(_memory.buffer.slice(offset, offset + length));
      value_stack.push({ type: 7, value: arr });
    },
    push_string: (name_offset: number, name_length: number) => {
      const name = td.decode(
        _memory.subarray(name_offset, name_offset + name_length)
      );
      value_stack.push({ type: 8, value: name });
    },
    push_list: (length: number) => {
      const values: NbtValue[] = new Array(length);
      for (let i = 0; i < length; i++) {
        values[length - i - 1] = value_stack.pop()!;
      }
      value_stack.push({ type: 9, values });
    },
    push_compound: (
      name_offset: number,
      name_length: number,
      entry_count: number
    ) => {
      const result: Record<string, NbtValue> = {};
      let i = 0;
      while (i < entry_count) {
        const value = value_stack.pop()!;
        const name = value_stack.pop()!;
        if (name.type !== 8) {
          throw new Error("Expected string name for compound entry");
        }
        result[name.value] = value;
        i++;
      }
      value_stack.push({
        type: 10,
        name: td.decode(
          _memory.subarray(name_offset, name_offset + name_length)
        ),
        value: result,
      });
    },
    push_int_array: (offset: number, length: number) => {
      // Create a copy to avoid memory alignment issues
      const sourceArray = new DataView(_memory.buffer, offset, length * 4);
      const arr = new Int32Array(length);
      for (let i = 0; i < length; i++) {
        arr[i] = sourceArray.getInt32(i * 4, use_le);
      }
      value_stack.push({ type: 11, value: arr });
    },
    push_long_array: (offset: number, length: number) => {
      const view = new DataView(_memory.buffer, offset, length * 8);
      const arr = new BigInt64Array(length);
      for (let i = 0; i < length; i++) {
        arr[i] = view.getBigInt64(i * 8, use_le);
      }
      value_stack.push({ type: 12, value: arr });
    },
  },
});
const buf = module.exports.memory as WebAssembly.Memory;
const parse_wasm = module.exports.parse as (root: 0 | 1, le: 0 | 1) => void;
function growToFit(bytes: number): void {
  const currentSize = buf.buffer.byteLength;
  const requiredSize = bytes + 65536; // 64 KiB
  if (currentSize < requiredSize) {
    const newSize = Math.ceil(requiredSize / 65536);
    buf.grow(newSize - currentSize / 65536);
  }
}
export function parse(buffer: ArrayBuffer, is_le: boolean = true): NbtValue {
  growToFit(buffer.byteLength);
  const view = new Uint8Array(buf.buffer);
  _memory = view;
  view.fill(0);
  view.set(new Uint8Array(buffer), 0);
  use_le = is_le;
  parse_wasm(1, is_le ? 1 : 0);
  return value_stack.pop()!;
}
export const buffer = bytes.buffer;
export { module };
