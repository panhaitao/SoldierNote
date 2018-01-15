public: html 
	rsync -av HTML/* root@207.246.93.246:/usr/share/nginx/html/ 

html: 
	bash ../Scripts/md2web.sh

clean:
	rm -rvf HTML/
	rm -rvf WIKI/
