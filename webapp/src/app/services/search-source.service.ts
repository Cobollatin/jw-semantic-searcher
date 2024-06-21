import { Injectable } from "@angular/core";
import { Observable, of } from "rxjs"; // Asegúrate de importar 'of' desde RxJS
import { catchError } from "rxjs/operators";
import { ComponentError, Document } from "../models";
import { PaginatedList } from "../models/paginated-list";

@Injectable({
  providedIn: "root",
})
export class SearchSourceService {
  constructor() {}

  public searchSources(query: string): Observable<PaginatedList<Document>> {
    // Datos estáticos para simular una respuesta
    const staticDocuments: Document[] = [
      {
        Id: "1",
        Title: "The Impact of Artificial Intelligence on Society",
        Content:
          "Artificial intelligence (AI) is rapidly transforming many aspects of our society, including healthcare, transportation, finance, and entertainment...",
        Url: "https://www.example.com/document-1",
      },
      {
        Id: "2",
        Title: "Climate Change: Causes, Effects, and Solutions",
        Content:
          "Climate change, also known as global warming, refers to the long-term change in Earth's climate patterns. It is primarily caused by human activities such as burning fossil fuels, deforestation, and industrial processes...",
        Url: "https://www.example.com/document-2",
      },
      {
        Id: "3",
        Title: "The Future of Renewable Energy Sources",
        Content:
          "Renewable energy sources, such as solar, wind, and hydroelectric power, are becoming increasingly important as we seek to reduce our reliance on fossil fuels and mitigate the impacts of climate change...",
        Url: "https://www.example.com/document-3",
      },
      {
        Id: "4",
        Title: "Exploring the Mysteries of the Deep Sea",
        Content:
          "The deep sea, also known as the abyssal zone, is the largest habitat on Earth. It is home to a wide variety of unique and often bizarre creatures, many of which have yet to be discovered...",
        Url: "https://www.example.com/document-4",
      },
      {
        Id: "5",
        Title: "The History and Evolution of Artificial Intelligence",
        Content:
          "The concept of artificial intelligence (AI) has been around for centuries, but it wasn't until the mid-20th century that significant progress was made in its development. Since then, AI has become an integral part of many aspects of our daily lives...",
        Url: "https://www.example.com/document-5",
      },
      {
        Id: "6",
        Title: "The Importance of Biodiversity Conservation",
        Content:
          "Biodiversity refers to the variety of life forms on Earth, including plants, animals, and microorganisms, as well as the ecosystems in which they live. It is essential for maintaining ecosystem stability, providing ecosystem services, and supporting human well-being...",
        Url: "https://www.example.com/document-6",
      },
      {
        Id: "7",
        Title: "Understanding Quantum Computing: Concepts and Applications",
        Content:
          "Quantum computing is a rapidly advancing field that utilizes the principles of quantum mechanics to perform complex calculations at speeds far beyond what is possible with classical computers. It has the potential to revolutionize fields such as cryptography, drug discovery, and optimization...",
        Url: "https://www.example.com/document-7",
      },
      {
        Id: "8",
        Title: "The Role of Artificial Intelligence in Healthcare",
        Content:
          "Artificial intelligence (AI) is revolutionizing the healthcare industry by enabling more accurate diagnosis, personalized treatment plans, and improved patient outcomes. From medical imaging and diagnostics to drug discovery and telemedicine, AI is reshaping the way healthcare is delivered...",
        Url: "https://www.example.com/document-8",
      },
      {
        Id: "9",
        Title: "The Impact of Social Media on Society",
        Content:
          "Social media platforms such as Facebook, Twitter, and Instagram have transformed the way we communicate, share information, and interact with one another. While social media offers many benefits, including connecting people across the globe and facilitating social movements, it also raises concerns about privacy, online harassment, and the spread of misinformation...",
        Url: "https://www.example.com/document-9",
      },
      {
        Id: "10",
        Title: "Advancements in Space Exploration: Past, Present, and Future",
        Content:
          "Space exploration has always captured the imagination of humanity, from the first human steps on the Moon to the exploration of distant planets and beyond. Recent advancements in space technology, such as reusable rockets, robotic missions, and private spaceflight companies, are opening up new possibilities for exploring the cosmos...",
        Url: "https://www.example.com/document-10",
      },
      {
        Id: "11",
        Title: "The Benefits of Meditation for Mental Health",
        Content:
          "Meditation has been practiced for thousands of years as a way to promote relaxation, reduce stress, and cultivate inner peace. Research has shown that regular meditation practice can have a positive impact on mental health, reducing symptoms of anxiety, depression, and other mood disorders...",
        Url: "https://www.example.com/document-11",
      },
      {
        Id: "12",
        Title: "The Future of Work: Trends and Challenges in the Digital Age",
        Content:
          "The nature of work is rapidly evolving in the digital age, driven by advancements in technology, globalization, and changing demographics. Automation, artificial intelligence, and the gig economy are reshaping the labor market, creating new opportunities and challenges for workers and employers alike...",
        Url: "https://www.example.com/document-12",
      },
      {
        Id: "13",
        Title: "The Importance of Early Childhood Education",
        Content:
          "Early childhood education plays a crucial role in the development of young children, providing them with the foundation for future learning and success. High-quality early childhood programs support children's cognitive, social, emotional, and physical development, setting them on a path towards lifelong learning and achievement...",
        Url: "https://www.example.com/document-13",
      },
      {
        Id: "14",
        Title:
          "The Ethics of Artificial Intelligence: Challenges and Considerations",
        Content:
          "As artificial intelligence (AI) becomes increasingly integrated into our daily lives, ethical considerations surrounding its use are becoming more important. Issues such as bias in algorithms, privacy concerns, and the impact on jobs and society must be carefully addressed to ensure that AI technologies are developed and deployed responsibly...",
        Url: "https://www.example.com/document-14",
      },
      {
        Id: "15",
        Title: "The Future of Autonomous Vehicles",
        Content:
          "Autonomous vehicles, also known as self-driving cars, have the potential to revolutionize transportation by reducing accidents, traffic congestion, and pollution. However, widespread adoption of autonomous vehicles also raises questions about safety, regulation, and the impact on jobs in the transportation sector...",
        Url: "https://www.example.com/document-15",
      },
      {
        Id: "16",
        Title: "The Rise of Virtual Reality: Applications and Implications",
        Content:
          "Virtual reality (VR) technology has advanced rapidly in recent years, enabling immersive experiences in gaming, entertainment, education, and more. As VR becomes more accessible and affordable, its applications are expanding into areas such as healthcare, architecture, and training simulations...",
        Url: "https://www.example.com/document-16",
      },
      {
        Id: "17",
        Title:
          "The Psychology of Happiness: Factors and Strategies for Well-Being",
        Content:
          "Happiness is a complex and multifaceted concept that is influenced by a variety of factors, including genetics, personality, and life circumstances. Research in positive psychology has identified several strategies for enhancing happiness and well-being, such as practicing gratitude, cultivating strong social connections, and pursuing meaningful goals...",
        Url: "https://www.example.com/document-17",
      },
      {
        Id: "18",
        Title: "The Future of Food: Sustainable Agriculture and Nutrition",
        Content:
          "As the global population continues to grow, ensuring food security and sustainability is becoming increasingly important. Sustainable agriculture practices, such as organic farming, agroforestry, and precision agriculture, aim to minimize environmental impact while maximizing crop yields and promoting biodiversity...",
        Url: "https://www.example.com/document-18",
      },
      {
        Id: "19",
        Title: "The Promise and Perils of Genetic Engineering",
        Content:
          "Genetic engineering technology, such as CRISPR-Cas9, holds great promise for addressing pressing challenges in areas such as medicine, agriculture, and environmental conservation. However, the widespread use of genetic engineering also raises ethical, social, and environmental concerns that must be carefully considered...",
        Url: "https://www.example.com/document-19",
      },
      {
        Id: "20",
        Title: "The Impact of Social Media on Mental Health",
        Content:
          "While social media offers many benefits, including connecting people across the globe and facilitating social movements, it also raises concerns about privacy, online harassment, and the spread of misinformation. Research has shown that excessive use of social media can negatively impact mental health, leading to feelings of loneliness, depression, and anxiety...",
        Url: "https://www.example.com/document-20",
      },
      // Puedes agregar más documentos según sea necesario
    ];

    // Empaqueta los datos estáticos en un objeto PaginatedList
    const staticResponse: PaginatedList<Document> = {
      items: staticDocuments,
      total: staticDocuments.length,
      page: 1,
      pageSize: staticDocuments.length, // O ajusta el pageSize según sea necesario
    };

    // Devuelve los datos estáticos como un observable utilizando el operador 'of' de RxJS
    return of(staticResponse).pipe(
      catchError((error: unknown) => {
        // Manejo de errores aquí si es necesario
        return of({} as PaginatedList<Document>);
      })
    );
  }
}
