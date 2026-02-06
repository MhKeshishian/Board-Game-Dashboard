"use client";

import "./PageTabs.css";
import SaveButton from "@/components/SaveButton/SaveButton";

export default function PageTabs({ activePage, setActivePage }) {
  return (
    <div className="page-tabs">
        <div className="page-tabs-left">
            <button type="button" className={activePage === 0 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(0)}>Page 1</button>
            <button type="button" className={activePage === 1 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(1)}>Page 2</button>
            <button type="button" className={activePage === 2 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(2)}>Page 3</button>
            <button type="button" className={activePage === 3 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(3)}>Page 4</button>
            <button type="button" className={activePage === 4 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(4)}>Page 5</button>
            <button type="button" className={activePage === 5 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(5)}>Page 6</button>
            <button type="button" className={activePage === 6 ? "page-tab active" : "page-tab"} onClick={() => setActivePage(6)}>Page 7</button>
        </div>

        <SaveButton />
    </div>
  );
}
