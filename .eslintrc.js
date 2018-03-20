module.exports = {
  "parser": "babel-eslint",
  "extends": "airbnb-base",
  "rules": {
    "eqeqeq": "off",
    "no-new": "off",
    "comma-dangle": "off",
    "import/first": "off",
    "import/prefer-default-export": "off",
    "import/no-extraneous-dependencies": "off",
    "arrow-body-style": "off",
    "no-useless-escape": "off",
    "no-underscore-dangle": "off",
    "no-param-reassign": "off",
    "consistent-return": "off",
    "default-case": "off"
  },
  "globals": {
    "document": true,
    "fetch": true,
    "window": true,
    "localStorage": true,
    "Event": true
  }
};
