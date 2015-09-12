# gitcafe-maid
gitcafe-maid 利用 gitcafe 提供的 webhook 监听分支的 push 行为 自动启动测试 并把结果通知到
slack/瀑布 中 还可以在提供的回调函数中执行自动部署.  

## Installation

$ gem install gitcafe-maid

## Usage

1. 增加配置文件 示例在example目录下
2. 在 gitcafe 相应项目里设置 push webhook
3. 在配置文件的目录下执行 `RACK_ENV=production gitcafe-maid` 会开始监听本机的4567端口, 等待 gitcafe webhook 调用.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xyuwang/gitcafe-maid.
