# it_queue.rb README #

This script checks the YAML-frontmatter of posts living in a Dropbox-directory. If it finds a post which is marked as `published:true` and which `date:` is in the past, it starts to build the blog, in this case [instant-thinking.de](http://instant-thinking.de/) and publishes it to the web via `rsync`. This should work with other  [Octopress](http://octopress.org/)-blogs too.

I'll write a blogpost with further details and link to it here in the near future...
