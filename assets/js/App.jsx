import React, { Component } from "react";
import Card from "./Card.jsx";

class App extends Component {
  constructor() {
    super();
    this.state = {
      searchText: "",
      isLoading: false,
      isValid: false,
      items: []
    }

    this.handleSearchClick = this.handleSearchClick.bind(this);
    this.handleInput = this.handleInput.bind(this);
  }

  handleInput(event) {
    this.setState({
      searchText: event.target.value
    });
  }

  handleSearchClick(event) {
    const { searchText, isValid, isLoading } = this.state;

    if (!isLoading) {
      this.setState({
        isLoading: true,
        isValid: false
      })

      this.search(searchText)
        .then(response => response.json())
        .then(json => this.setState({
          items: json.data,
          isValid: true,
          isLoading: false
        }));
    }
  }

  search(query) {
    return fetch("/api/search", {
      "method": "POST",
      "headers": new Headers({
        "Accept": "application/json",
        "Content-Type": "application/json"
      }),
      "body": JSON.stringify({ query: query })
    })
  }


  render() {
    const { searchText, items, isValid, isLoading } = this.state;

    return (
      <div className="container">
        <div className="field has-addons">
          <div className="control">
            <input onChange={this.handleInput} value={searchText} className="input" type="text" placeholder="Search" />
          </div>
          <div className="control">
            <a onClick={this.handleSearchClick} className="button is-primary">Search</a>
          </div>
        </div>

        {isLoading && <div className="loader" />}

        {!isLoading && isValid && items.map((item) =>
          <Card key={item.id} {...item} />
        )}

      </div>
    )
  }
}

export default App;