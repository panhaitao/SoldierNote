public: html
	rsync -av HTML/* root@207.246.93.246:/usr/share/nginx/html/ --delete

html: clean
	bash md2web.sh

clean:
	rm -rvf HTML/
