/// <reference types="vite/client" />
declare module "*.wat" {
  import x from "*.wasm?raw";
  export default x;
}