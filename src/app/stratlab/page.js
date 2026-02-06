"use client";

import { useState } from "react";
import Sidebar from "@/components/Sidebar/Sidebar";
import Dashboard from "@/components/Dashboard/Dashboard";
import Notes from "@/components/Notes/Notes";
import PageTabs from "@/components/PageTabs/PageTabs";

export default function Home() {
  const [activePage, setActivePage] = useState(0);

  return (
    <div className="app-layout">
      <Sidebar />
      <div className="main-content">
        <Dashboard activePage={activePage} />
        <Notes />
        <PageTabs activePage={activePage} setActivePage={setActivePage} />
      </div>
    </div>
  );
}
