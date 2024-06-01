/// 리스트의 뒷부분을 잘라서 반환해주는 함수가 구현되어 있는 extension
extension ListExtensions<T> on List<T> {
  List<T> takeLast(int n) {
    // 리스트의 길이가 n보다 작거나 같으면 전체 리스트를 반환
    if (n >= this.length) {
      return this;
    }
    // 그렇지 않다면, 마지막 n개의 요소를 반환
    return this.sublist(this.length - n);
  }
}