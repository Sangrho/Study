## Git Issue
- PR시, Merge Conflict(in github) 문제 발생
    ```
    git pull upstream master
    git status # conflict 된 파일을 찾는다.
    vi /foo/bar/<conflict file> # conflict 된 부분을 수정한다.
    git add /foo/bar/<conflict file>
    git commit -m "<comment>"
    git pull origin master
    git push
    ```