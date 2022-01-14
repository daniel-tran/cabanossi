:: Stopping the server means stopping this script, so don't use pushd and popd here since popd won't be actioned anyway
cd %~dp0\article-parser-server && npm run start
