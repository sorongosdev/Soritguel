import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {  
    final micTopMargin = MediaQuery.of(context).size.height * 0.1;
    final textFieldTopMargin =
        MediaQuery.of(context).size.height * 0.03; // 화면 높이의 5%를 마진으로 설정
    final textFieldSideMargin =
        MediaQuery.of(context).size.width * 0.05; // 화면 너비의 10%를 마진으로 설정
    final textFieldMaxHeight =
        MediaQuery.of(context).size.height * 0.6; // 화면 높이의 50%를 최대 높이로 설정
    final buttonRowSideMargin =
        MediaQuery.of(context).size.width * 0.05; // 화면 너비의 10%를 마진으로 설정

    return Scaffold(
      // 앱바
      appBar: AppBar(
        title: Text('STT'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // 더보기 버튼이 눌렸을 때
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // 마이크 아이콘
          Container(
            margin: EdgeInsets.only(top: micTopMargin),
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue,
              child: const Icon(Icons.mic),
            ),
          ),

          // 설명 텍스트
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            // Padding을 이용해 상단 마진을 설정할 수 있습니다.
            child: Text(
              '마이크 아이콘을 클릭한 후, 화면에 말을 하면 \n하단에 텍스트로 표시됩니다.',
              style: TextStyle(fontSize: 16.0), // 텍스트 크기, 색상 등 스타일을 설정할 수 있습니다.
              textAlign: TextAlign.center,
            ),
          ),

          // 텍스트 필드
          Container(
            margin: EdgeInsets.only(
                top: textFieldTopMargin,
                left: textFieldSideMargin,
                right: textFieldSideMargin),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            height: textFieldMaxHeight,
            child: const SingleChildScrollView(
              child: TextField(
                maxLines: null, // 줄 바꿈에 따라 자동으로 늘어나도록 설정
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 하단 버튼 행
          Container(
            margin: EdgeInsets.symmetric(horizontal: buttonRowSideMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Expanded(
                  child: Text(
                    '텍스트 크기',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('크게'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('작게'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}