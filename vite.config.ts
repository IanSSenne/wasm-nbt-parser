import { defineConfig } from 'vite'// src/index.ts
import { relative, resolve } from "pathe";
import fse from "fs-extra";

/**!
 * the wat to wasm plugin for vite was modified from the vite-plugin-wat to fit my requirements.
 * it falls under this license:
 * 
 * MIT License

Copyright (c) 2022 mys1024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

// src/wabt.ts
import wabt from "wabt";
async function wat2wasm(wat) {
  const wabtModule = await wabt();
  const wasmModule = wabtModule.parseWat("", wat);
  wasmModule.validate();
  const res = wasmModule.toBinary({
    write_debug_names:true,
  }).buffer;
  

  console.log("built wasm module", res.byteLength, "bytes");
  return res;
}

// src/index.ts
var WAT_ID_REG = /\.wat$/;
function isWatId(id) {
  return WAT_ID_REG.test(id);
}
function resolveWasmId(watId, cwd, wasmDir) {
  return resolve(wasmDir, relative(cwd, watId).replace(WAT_ID_REG, ".wasm"));
}
var src_default = () => {
  const cwd = resolve("./");
  const storeDir = resolve(cwd, "node_modules", ".vite-plugin-wat");
  const wasmDir = resolve(storeDir, "wasm");
  return {
    name: "vite-plugin-wat",
    config: () => ({
      server: { watch: { ignored: [wasmDir] } }
    }),
    buildStart: () => {
      fse.removeSync(wasmDir);
    },
    resolveId: (id) => {
      return isWatId(id) ? id : void 0;
    },
    transform: async (code, id) => {
      if (!isWatId(id))
        return;
      const wasmId = resolveWasmId(id, cwd, wasmDir);
      await fse.ensureFile(wasmId);
      const data = await wat2wasm(code);
      await fse.writeFile(wasmId,data);
      return `export default new Uint8Array([${[...data].join(",")}]);`;
    }
  };
};

export default defineConfig({
  build: {
    lib: {
      entry: './lib/main.ts',
      name: 'nbt-lib',
      fileName: 'nbt-lib',
    },
  },
  plugins: [src_default()]
})
