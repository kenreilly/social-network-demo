import 'package:flutter/material.dart';
import 'package:core/core.dart';

void main() { runApp(MyApp()); }

// class TestConcept extends Serializable {

// 	@serialize

// }

class MyApp extends StatelessWidget {

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Flutter Demo',
			theme:ThemeData.dark(),
			home: MyHomePage(title: 'Social Network Demo'),
		);
	}
}

class MyHomePage extends StatefulWidget {

	MyHomePage({Key key, this.title}) : super(key: key);

	final String title;

	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

	int _counter = 0;

	TestModel testmodel;

	void _incrementCounter() {

		setState(() {
			_counter++;
		});

	}

	_MyHomePageState() {

		// TestModel tm1 = TestModel(b: true, i: 1, s: 'hi');
  		// TestModel tm2 = Serializable.of<TestModel>(tm1.data);
    	// testmodel = Serializable.cast(tm2.runtimeType, tm2.data);
		
	}

	@override
	Widget build(BuildContext context) {
		
		return Scaffold(
			appBar: AppBar(title: Text(widget.title)),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Text('Ü have pushed the button this many times:'),
						Text('$_counter', style: Theme.of(context).textTheme.headline4),
						// Text(testmodel.s),
						// Text(testmodel.i.toString())
					]
				)
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _incrementCounter,
				tooltip: 'Increment',
				child: Icon(Icons.add)
			)
		);
	}
}