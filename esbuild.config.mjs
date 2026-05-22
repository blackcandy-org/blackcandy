import * as esbuild from "esbuild"
import { readdirSync } from "node:fs"

const watch = process.argv.includes("--watch")
const minify = !process.argv.includes("--dev")

const externalAssets = ["*.svg", "*.png", "*.jpg", "*.gif", "*.woff", "*.woff2"]

const jsEntryPoints = readdirSync("app/javascript")
  .filter(file => /\.[a-z]+$/i.test(file))
  .map(file => `app/javascript/${file}`)

const configs = [
  {
    entryPoints: jsEntryPoints,
    bundle: true,
    sourcemap: true,
    format: "esm",
    outdir: "app/assets/builds",
    publicPath: "/assets",
    minify,
    external: externalAssets
  },
  {
    entryPoints: ["app/assets/stylesheets/application.css"],
    bundle: true,
    outdir: "app/assets/builds",
    minify,
    external: externalAssets
  }
]

if (watch) {
  const contexts = await Promise.all(configs.map(esbuild.context))
  await Promise.all(contexts.map(ctx => ctx.watch()))
} else {
  await Promise.all(configs.map(esbuild.build))
}
