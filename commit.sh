#!/bin/bash

FILE='package.json'

if [ ! -f "$FILE" ]; then
    #if doens't have package.json, create and add to gitignore
    #probabily isn't node project

    echo "package.json not found
    Creating a configuration file and adding to .gitignore"

    yarn init -y
    echo "" >> .gitignore
    echo "" >> .gitignore
    echo "###### Pre commit #######" >> .gitignore
    echo "package.json" >> .gitignore
    echo "node_modules/" >> .gitignore
    echo "yarn.lock" >> .gitignore
fi

echo "Running yarn add @commitlint/config-conventional @commitlint/cli --dev"
yarn add @commitlint/config-conventional @commitlint/cli --dev

echo "npx husky install"
npm_config_yes=true npx husky install 

echo "Creating commitlint.config.js"
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js
echo "commitlint.config.js" >> .gitignore

echo "npx husky add .husky/commit-msg 'npx --no-install commitlint --edit \"$1\"'"
npx husky add .husky/commit-msg 'npx --no-install commitlint --edit "$1"'

echo "yarn add commitizen --dev"
yarn add commitizen --dev

echo "yarn add commitizen init cz-conventional-changelog --yarn --dev --exact"
yarn add commitizen init cz-conventional-changelog --yarn --dev --exact


echo "Adding conventional-changelog to package.json"
cat package.json | jq 'setpath(["config","commitizen", "path"]; "./node_modules/cz-conventional-changelog")' > tmp.json

rm package.json

mv tmp.json package.json

echo "Creating hook prepare-commig-msg"
echo "#!/bin/sh
. \"\$(dirname \"\$0\")/_/husky.sh\"

exec < /dev/tty && node_modules/.bin/cz --hook || true
" > ./.husky/prepare-commit-msg

echo "Add permission to execute hooks"
chmod ug+x .husky/*
chmod ug+x .git/hooks/*


echo ".husky/" >> .gitignore
