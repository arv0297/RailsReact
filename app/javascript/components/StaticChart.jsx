// app/javascript/components/StaticChart.jsx
//matched name tite
import React from "react"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"

const data = [
    { month: "Jan", sales: 400 },
    { month: "Feb", sales: 300 },
    { month: "Mar", sales: 600 },
    { month: "Apr", sales: 800 },
    { month: "May", sales: 500 },
]

export default function StaticChart() {
    return (
        <div style={{ width: "100%", height: 400 }}>
            <ResponsiveContainer>
                <BarChart data={data}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip />
                    <Bar dataKey="sales" fill="#8884d8" />
                </BarChart>
            </ResponsiveContainer>
        </div>
    )
}