## Git Issue

### PR시, Merge Conflict(in github) 문제 발생
```
git pull upstream master
git status # conflict 된 파일을 찾는다.
vi /foo/bar/<conflict file> # conflict 된 부분을 수정한다.
git add /foo/bar/<conflict file>
git commit -m "<comment>"
git pull origin master
git push
```

### git pull, merge conflict
```
git stash // 임시 사항 저장
git pull // pull
git stash pop // 상태를 HEAD로 변경
// 이후 conflict한 파일에서 stream을 선택후, 비선택 내용 제거
git commit -m "conflict가 해결된 파일"
git push
```