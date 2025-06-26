import "./style.css";
import { parse } from "../lib/main";

fetch("/test_name.mcstructure").then(async (response) => {
// fetch("/noheader.level.dat").then(async (response) => {
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  const buffer = await response.arrayBuffer();
  console.log("buffer", buffer);
  const view = new Uint8Array(buffer);
  // console.log("view", view);
  console.log("view length", view.length);
  console.log("view[0]", view[0]);
  console.time("parse");
  console.log(parse(buffer));
  console.timeEnd("parse");
});
