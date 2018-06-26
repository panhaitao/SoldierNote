public: html 
	cp -av Solution/images/ HTML/Solution/
	cp -av Application/images HTML/Application/
	rsync -av HTML/* root@blog.onwalk.net:/usr/share/nginx/html/ --delete 

html: 
	bash ../Scripts/md2web.sh

clean:
	rm -rvf HTML/
	rm -rvf WIKI/
