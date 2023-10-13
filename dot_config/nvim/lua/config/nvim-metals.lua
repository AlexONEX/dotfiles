metals_config = require("metals").bare_config()
  metals_config.settings = {
    showImplicitArguments = true,
    excludedPackages = {
      "akka.actor.typed.javadsl",
      "com.github.swagger.akka.javadsl"
    }
  }
