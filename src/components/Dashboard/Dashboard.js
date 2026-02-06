"use client";

import React from "react";
import ReactGridLayout from "react-grid-layout";
import './Dashboard.css'

export default class Dashboard extends React.PureComponent {
    static defaultProps = {
        cols: 12,
        rowHeight: 100,
        isDraggable: true,
        isResizable: true,
        width: 2000,
        activePage: 0
    };

  constructor(props) {
    super(props);

    this.state = {
        itemsByPage: [[], [], [], [], [], [], []],
        counterByPage: [0, 0, 0, 0, 0, 0, 0]
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

    const pageIndex = this.props.activePage;
    const moduleId = e.dataTransfer.getData("text/plain");

    const itemsCopy = [...this.state.itemsByPage];
    const counterCopy = [...this.state.counterByPage];

    const newId = "n" + counterCopy[pageIndex];

    const newItem = {
        i: newId,
        x: (itemsCopy[pageIndex].length * 2) % this.props.cols,
        y: Infinity,
        w: 1,
        h: 1,
        moduleId: moduleId
    };

    itemsCopy[pageIndex] = itemsCopy[pageIndex].concat(newItem);
    counterCopy[pageIndex] = counterCopy[pageIndex] + 1;

    this.setState({ itemsByPage: itemsCopy, counterByPage: counterCopy });
    }

  onRemoveItem(id) {
    const pageIndex = this.props.activePage;

    const itemsCopy = [...this.state.itemsByPage];
    itemsCopy[pageIndex] = itemsCopy[pageIndex].filter((x) => x.i !== id);

    this.setState({ itemsByPage: itemsCopy });
    }

  onLayoutChange(layout) {
    this.props.onLayoutChange?.(layout);
    }

  generateDOM() {
    const pageIndex = this.props.activePage;
    const items = this.state.itemsByPage[pageIndex];

    return items.map((el) =>
        <div key={el.i} data-grid={el} className="dash-module">
        <button className="dash-remove" onClick={() => this.onRemoveItem(el.i)}>x</button>
        <div className="dash-name">{el.moduleId}</div>
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
