import React, { useEffect, useState } from "react";
import cable from "../cable"

export default function App() {
  const [lists, setLists] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    async function fetchData() {
      try {
        const response = await fetch("/api/v1/cards");
        const data = await response.json();
        setLists(data);
      } catch (error) {
        console.error("Failed to fetch lists:", error);
      } finally {
        setLoading(false);
      }
    }
    
    fetchData();
    
    const subscription = cable.subscriptions.create("ListsChannel", {
      received: (updatedLists) => {
        setLists(updatedLists); // Update lists in real-time
      },
    });
    
    return () => {
      subscription.unsubscribe();
    };
  }, []);
  
  if (loading) {
    return (
      <div className="w-full h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-gray-400">Loading...</div>
      </div>
    );
  }
  
  if (lists.length === 0) {
    return (
      <div className="w-full h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-gray-400">No lists available, please go to your Trello board and create a list there first</div>
      </div>
    );
  }
  
  return (
    <div className="w-full h-screen bg-gray-100 flex p-4 gap-4 overflow-x-auto">
      {lists.map((list) => (
        <div
          key={list.id}
          className="rounded shadow p-4 bg-white flex flex-col w-64"
        >
          <h2 className="font-bold text-gray-900 text-xl mb-2">{list.name}</h2>
          {list.cards.length === 0 ? (
            <div className="text-gray-400">No cards</div>
          ) : (
            <ul>
              {list.cards.map((card) => (
                <li key={card.id} className="border-b py-2 text-gray-800">
                  {card.name}
                </li>
              ))}
            </ul>
          )}
        </div>
      ))}
    </div>
  );
}
