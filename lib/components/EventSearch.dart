import 'package:flutter/material.dart';
import 'package:fyvent/models/event.dart';
import 'package:fyvent/components/EventCard.dart';
import 'package:fyvent/utils/api_facade.dart';
import 'package:fyvent/components/DropdownOption.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EventSearch extends SearchDelegate<String> {
  final List categories;
  EventSearch({this.categories});

  Map selectedCategory = {"id": 246, "name": "All Events", "type": "category"};

  void _updateQuery(Map activeValue) {
    if (activeValue.isNotEmpty) {
      if (activeValue["type"] == "category") selectedCategory = activeValue;
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    TextStyle optionTextStyle =
        new TextStyle(fontSize: 16.0, color: Colors.black);
    void _showFilterOptions() {
      showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15.0),
                  child: new Text("Filter events by:"),
                ),
                new ListTile(
                    leading: new Icon(Icons.category),
                    title: new Text(
                      'Category',
                      style: optionTextStyle,
                    ),
                    trailing: DropdownOption(categories, categories[0], _updateQuery)),
                new Padding(padding: const EdgeInsets.only(bottom: 10.0))
              ],
            );
          });
    }

    return [
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: () =>
            _showFilterOptions(), //Need to set the query based on the input from _showFilterOptions()
      ),
      IconButton(
        //Clear results
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //Widget to display before the search query in the AppBar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (query.length == 0) {
      return Container(
          width: width,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                new Icon(
                  Icons.search,
                  size: 50.0,
                  color: Colors.black26,
                ),
                new Padding(padding: const EdgeInsets.only(top: 10.0)),
                new Text(
                  "Search for related events.",
                  style: new TextStyle(fontSize: 16.0, color: Colors.black26),
                )
              ]));
    }
    return FutureBuilder<List<Event>>(
        future: searchEventsByCategory(selectedCategory["id"], query),
        builder: (BuildContext context, AsyncSnapshot<List<Event>> events) {
          if (events.connectionState == ConnectionState.waiting) {
            return Container(
                width: width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Center(
                          child: SpinKitRipple(
                        color: Colors.teal,
                        size: 50.0,
                      ))
                    ]));
          }
          if (!events.hasData || events.data.length == 0) {
            return Container(
                width: width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Text(
                        "Sorry, there are no events related to your search!",
                        style: new TextStyle(
                            fontSize: 16.0, color: Colors.black26),
                      )
                    ]));
          }
          return buildEventSuggestions(events.data);
        });
  }

  Widget buildEventSuggestions(List<Event> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }
  
}
