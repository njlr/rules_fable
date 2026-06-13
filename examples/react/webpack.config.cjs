const path = require("path");

module.exports = {
  output: {
    filename: "[name].js",
    path: path.resolve(process.cwd(), "dist"),
  },
  resolve: {
    modules: [
      path.resolve(process.cwd(), process.env.BAZEL_BINDIR || "bazel-bin", "node_modules"),
      "node_modules",
    ],
  },
  devServer: {
    historyApiFallback: true,
    host: "0.0.0.0",
    port: 8080,
    static: {
      directory: __dirname,
    },
  },
};
