"use client";

import { useState } from "react";
import ReactGridLayout from "react-grid-layout";
import "./Dashboard.css";

export default function Dashboard(props) {
    const [itemsByPage, setItemsByPage] = useState([[], [], [], [], [], [], []]);
    const [counterByPage, setCounterByPage] = useState([0, 0, 0, 0, 0, 0, 0]);

    function handleDragOver(e) {
        e.preventDefault();
    }

    function handleDrop(e) {
        e.preventDefault();

        const pageIndex = props.activePage;
        const moduleId = e.dataTransfer.getData("text/plain");

        const itemsCopy = [...itemsByPage];
        const counterCopy = [...counterByPage];

        const newId = "n" + counterCopy[pageIndex];

        const perRow = 7;
        const index = itemsCopy[pageIndex].length;

        const newItem = {
        i: newId,
        x: (index % perRow),
        y: Math.floor(index / perRow),
        w: 1,
        h: 1,
        moduleId: moduleId
        };

        itemsCopy[pageIndex] = itemsCopy[pageIndex].concat(newItem);
        counterCopy[pageIndex] = counterCopy[pageIndex] + 1;

        setItemsByPage(itemsCopy);
        setCounterByPage(counterCopy);
    }

    function onRemoveItem(id) {
        const pageIndex = props.activePage;

        const itemsCopy = [...itemsByPage];
        itemsCopy[pageIndex] = itemsCopy[pageIndex].filter((x) => x.i !== id);

        setItemsByPage(itemsCopy);
    }

    function onLayoutChange(layout) {
        if (props.onLayoutChange) props.onLayoutChange(layout);
    }

    function generateDOM() {
        const pageIndex = props.activePage;
        const items = itemsByPage[pageIndex];

        return items.map((el) =>
        <div key={el.i} data-grid={el} className="module-box">
            <button className="module-gear" type="button" onClick={() => alert("Config clicked. Backend logic goes here.")}><img src="/icons/gear.svg" /></button>
            <button className="module-remove" onClick={() => onRemoveItem(el.i)}>x</button>
            <div className="module-name">{el.moduleId}</div>
        </div>
        );
    }

    return (
        <div className="dashboard-area" onDragOver={handleDragOver} onDrop={handleDrop}>
        <ReactGridLayout
            cols={24}
            rowHeight={50}
            isDraggable={true}
            isResizable={true}
            width={2000}
            onLayoutChange={onLayoutChange}
        >
            {generateDOM()}
        </ReactGridLayout>
        </div>
    );
}
