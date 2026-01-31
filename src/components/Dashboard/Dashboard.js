"use client";

import React from "react";
import ReactGridLayout from "react-grid-layout";

export default class Dashboard extends React.PureComponent {
  static defaultProps = {
    cols: 12,
    rowHeight: 100,
    isDraggable: true,
    isResizable: true,
    width: 2000
  };

  constructor(props) {
    super(props);

    this.state = {
      items: [],
      newCounter: 0
    };

    this.handleDrop = this.handleDrop.bind(this);
    this.handleDragOver = this.handleDragOver.bind(this);
    this.onLayoutChange = this.onLayoutChange.bind(this);
  }

  handleDragOver(e) {
    e.preventDefault();
  }

  handleDrop(e) {
    e.preventDefault();

    const widgetName = e.dataTransfer.getData("text/plain");
    const newId = "n" + this.state.newCounter;

    this.setState({
      items: this.state.items.concat({
        i: newId,
        x: (this.state.items.length * 2) % this.props.cols,
        y: Infinity,
        w: 1,
        h: 1,
        widgetName: widgetName
      }),
      newCounter: this.state.newCounter + 1
    });
  }

  onRemoveItem(id) {
    this.setState({
      items: this.state.items.filter((x) => x.i !== id)
    });
  }

  onLayoutChange(layout) {
    this.props.onLayoutChange?.(layout);
  }

  generateDOM() {
    return this.state.items.map((el) =>
      <div key={el.i} data-grid={el} className="dash-widget">
        <button className="dash-remove" onClick={() => this.onRemoveItem(el.i)}>x</button>
        <div className="dash-name">{el.widgetName}</div>
      </div>
    );
  }

  render() {
    return (
      <div className="dashboard-area" onDragOver={this.handleDragOver} onDrop={this.handleDrop}>
        <ReactGridLayout {...this.props} onLayoutChange={this.onLayoutChange}>
          {this.generateDOM()}
        </ReactGridLayout>
      </div>
    );
  }
}
