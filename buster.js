var config = module.exports;

config["logo"] = {
  environment: "node",
  specs: ["spec/*.spec.coffee"],
  extensions: [require("buster-coffee")]
};
