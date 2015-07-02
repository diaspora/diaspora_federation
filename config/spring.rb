Spring.application_root = "./test/dummy"

root_path = Pathname.new(File.expand_path("."))
Spring.watcher = Spring::Watcher::Listen.new(root_path, 0.2)

Spring.watch("./lib/")
