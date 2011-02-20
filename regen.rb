$targets = {
  "README.textile" => nil,
  "guide.css" => nil
}

$targets.each do |f,m|
  $targets[f] = File.mtime f
end

def what_changed
  changed = []
  $targets.each do |f,m|
    new_mtime = File.mtime(f) 
    if new_mtime > $targets[f]
      changed << f
      $targets[f] = new_mtime
    end
  end
  changed
rescue
  puts "Someting went wrong? : #$!"
end

def regen
  puts ".running redcloth..."
  system "redcloth README.textile > README.textile.html"
  puts ".regenerated."
end

regen
while true
  sleep 1
  changed = what_changed
  if !changed.empty?
    puts "CHANGED: #{changed.inspect}"
    regen
  end
end
