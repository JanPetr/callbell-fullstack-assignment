import React, { useEffect, useState } from "react";

import cable from "../cable";

import NewCardModal from './NewCardModal';
import CardDetailModal from "./CardDetailModal";
import Toast from './Toast';

export default function App() {
  const [lists, setLists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [activeListId, setActiveListId] = useState(null);
  const [toastMessage, setToastMessage] = useState("");
  const [selectedCard, setSelectedCard] = useState(null);
  
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
        setLists(updatedLists);
      },
    });
    
    return () => {
      subscription.unsubscribe();
    };
  }, []);
  
  const handleAddCardClick = (trelloListID) => {
    setActiveListId(trelloListID);
    setIsModalOpen(true);
  };
  
  const handleCardCreation = async (cardData) => {
    try {
      const response = await fetch("/api/v1/cards", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...cardData, id_list: activeListId }),
      });

      if (response.ok) {
        setIsModalOpen(false);
      } else {
        throw new Error("Failed to create card");
      }
    } catch (error) {
      console.error("Error creating card:", error);
      setToastMessage("Failed to create the card. Please try again.");
    }
  };
  
  const handleToastClose = () => {
    setToastMessage("");
  };
  
  const handleCardClick = (card) => {
    setSelectedCard(card);
  };
  
  const closeCardDetailModal = () => {
    setSelectedCard(null);
  };
  
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
        <div className="text-gray-400">No lists available, please go to your <a className="underline" href="https://trello.com/b/riEjR2ZJ/callbell-full-stack-test" target="_blank">Trello board</a> and create a list there first</div>
      </div>
    );
  }
  
  return (
    <div className="w-full h-screen bg-gray-100">
      <h1 className="font-bold text-gray-900 text-2xl pt-5 pb-1 pl-4">Callbell full stack test board</h1>
      <div className="flex p-4 gap-4 overflow-x-auto">
        {lists.map((list) => (
          <div
            key={list.id}
            className="rounded shadow p-4 bg-white flex flex-col w-64"
          >
            <h2 className="font-bold text-gray-900 text-l mb-2">{list.name}</h2>
            {list.cards.length > 0 && (
              <ul>
                {list.cards.map((card) => (
                  <li
                    key={card.id}
                    className="py-2 text-gray-800 cursor-pointer hover:bg-gray-100 rounded border p-2 my-2 bg-gray-200 block"
                    onClick={() => handleCardClick(card)}
                  >
                    {card.name}
                  </li>
                ))}
              </ul>
            )}
            
            <button
              className="mt-2 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
              onClick={() => handleAddCardClick(list.trello_list_id)}
            >
              Add a new card
            </button>
          </div>
        ))}
        
        {isModalOpen && (
          <NewCardModal
            onClose={() => setIsModalOpen(false)}
            onSubmit={handleCardCreation}
          />
        )}
        
        {selectedCard && (
          <CardDetailModal
            card={selectedCard}
            onClose={closeCardDetailModal}
          />
        )}
        
        {toastMessage && <Toast message={toastMessage} onClose={handleToastClose} />}
      </div>
    </div>
  );
}
