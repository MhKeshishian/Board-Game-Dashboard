"use client"
import { useState } from 'react'
import ReactGridLayout from 'react-grid-layout'
import 'react-grid-layout/css/styles.css'
import 'react-resizable/css/styles.css'
import './Dashboardnew.css'

export default function Dashboard() {
  const [layout, setLayout] = useState([])
  const [modules, setModules] = useState({})

  return (
    <div className="dashboard-area">
      <ReactGridLayout
        className="layout"
        layout={layout}
        cols={12}
        rowHeight={30}
        width={1200}
        margin={[0, 0]}
      >
        {/* Modules will render here */}
      </ReactGridLayout>
    </div>
  )
}