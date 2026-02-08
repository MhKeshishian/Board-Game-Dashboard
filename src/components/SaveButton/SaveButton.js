"use client";

import "./SaveButton.css";

export default function SaveButton() {

    function handleSave() {
        alert("Save clicked. Backend logic goes here.");
    }

    return (
        <div className="save-button-container">
        <button type="button" className="save-button" onClick={handleSave}>
            Save
        </button>
        </div>
    );
}
