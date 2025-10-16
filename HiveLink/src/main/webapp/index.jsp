<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>HiveLink</title>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f8f9fb;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        header {
            width: 100%;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            padding: 20px 0;
            text-align: center;
        }

        header h1 {
            margin: 0;
            color: #333;
            font-weight: 600;
            font-size: 28px;
            letter-spacing: 1px;
        }

        .search-box {
            margin: 30px 0 10px;
            text-align: center;
        }

        .search-box input[type="text"] {
            width: 280px;
            padding: 10px 14px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 15px;
            transition: border-color 0.3s;
        }

        .search-box input[type="text"]:focus {
            border-color: #0078ff;
            outline: none;
        }

        .search-box button {
            padding: 10px 18px;
            margin-left: 6px;
            background-color: #0078ff;
            color: #fff;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 15px;
            transition: background-color 0.3s;
        }

        .search-box button:hover {
            background-color: #005fd1;
        }

        .help-text {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
            text-align: center;
        }

        .result-count {
            font-size: 14px;
            color: #555;
            margin-bottom: 10px;
            text-align: center;
        }

        .table-area {
            display: flex;
            justify-content: center;
            width: 100%;
            margin-top: 10px;
        }

        table {
            width: 700px;
            border-collapse: collapse;
            background-color: #ffffff;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            padding: 14px 16px;
            text-align: left;
        }

        th {
            background-color: #f2f4f8;
            color: #333;
            font-weight: 600;
            border-bottom: 2px solid #e0e0e0;
        }

        tr:nth-child(even) {
            background-color: #fafbfc;
        }

        tr:hover {
            background-color: #f1f5ff;
        }

        a.project-link {
            color: #0078ff;
            text-decoration: none;
            transition: color 0.2s;
        }

        a.project-link:hover {
            color: #005fd1;
            text-decoration: underline;
        }

        .no-result {
            text-align: center;
            color: #888;
            padding: 20px;
        }

        /* 페이징 */
        .pagination {
            margin-top: 15px;
            display: flex;
            justify-content: center;
            gap: 6px;
        }

        .pagination button {
            background-color: #fff;
            border: 1px solid #ccc;
            border-radius: 4px;
            padding: 6px 10px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s, color 0.3s;
        }

        .pagination button:hover {
            background-color: #0078ff;
            color: #fff;
        }

        .pagination button.active {
            background-color: #0078ff;
            color: #fff;
            border-color: #0078ff;
        }
    </style>
    
<script>
$(document).ready(function () {
    const projectList = [
        ["인천 2호선", "http://grkeeper.kr:8222"],
        ["공항철도 무선단말 시스템", "http://grkeeper.kr:9041"],
        ["Smart City", "http://grkeeper.kr:9051"],
        ["고압 시험반 원격 시험", "http://grkeeper.kr:9052"],
        ["혼잡도 관리 시스템", "http://grkeeper.kr:9053"],
        ["Airhub Chart", "http://grkeeper.kr:9054"],
        ["교통관제 시스템", "http://grkeeper.kr:9056"],
        ["TerraPort - Web Client", "http://grkeeper.kr:9057"],
        ["양양 양수발전 스케줄러", "http://grkeeper.kr:9091"],
        ["양양 양수발전", "http://grkeeper.kr:9092"],
        ["레이더 합성 영상", "http://grkeeper.kr:9093"],
        ["태풍 통보문", "http://grkeeper.kr:9094"],
        ["단기 예보", "http://grkeeper.kr:9095"],
        ["Help Desk", "http://grkeeper.kr:9096/index.do"],
        ["양양 양수발전(KOBA)", "http://grkeeper.kr:9097"],
        ["CLOUD 24365", "http://grkeeper.kr:24365"],
        ["CLOUD 24365 Admin", "http://grkeeper.kr:24366"]
    ];

    const tableBody = $("#tableBody");
    const pagination = $("#pagination");
    const resultCount = $("#resultCount");
    const searchInput = $("#searchKeyword");
    const searchBtn = $("#searchBtn");

    const rowsPerPage = 10;
    let currentPage = 1;
    let filteredList = projectList;

    function renderTable(data, page = 1) {
        const datacnt = data.length;
        tableBody.empty();
        const start = (page - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        const pageData = data.slice(start, end);

        if (data.length === 0) {
            tableBody.html('<tr><td colspan="2" class="no-result">검색 결과가 없습니다.</td></tr>');
            resultCount.text("총 0건");
            pagination.empty();
            return;
        }

        let text = "";
        $.each(pageData, function (index, item) {
            const name = item[0];
            const url = item[1];
            const num = start + index + 1;
            text += "<tr>"
                  + "<td>" + num + "</td>"
                  + "<td><a href='" + url + "' target='_blank' class='project-link'>" + name + "</a></td>"
                  + "</tr>";
        });

        tableBody.html(text);
        resultCount.text("총 " + datacnt + "건");
        renderPagination(datacnt, page);
    }

    function renderPagination(totalRows, current) {
        pagination.empty();
        const totalPages = Math.ceil(totalRows / rowsPerPage);
        let pageText = "";
        for (let i = 1; i <= totalPages; i++) {
            const activeClass = i === current ? "active" : "";
            pageText += "<button class='" + activeClass + "'>" + i + "</button>";
        }
        pagination.html(pageText);
        pagination.find("button").on("click", function () {
            currentPage = parseInt($(this).text());
            renderTable(filteredList, currentPage);
        });
    }

    function searchProjects() {
        const keyword = searchInput.val().trim();
        if (keyword.length < 2) {
            alert("검색어는 2글자 이상 입력해주세요.");
            filteredList = projectList;
        } else {
            filteredList = projectList.filter(p => p[0].includes(keyword));
        }
        currentPage = 1;
        renderTable(filteredList, currentPage);
    }

    renderTable(projectList, currentPage);
    searchBtn.on("click", searchProjects);
    searchInput.on("keypress", function (e) {
        if (e.which === 13) searchProjects();
    });
    
    $("#refresh").on("click", function () {
        location.reload();
    });
});
</script>

</head>

<body>
    <header>
        <h1>HiveLink</h1>
    </header>

    <section class="search-box">
        <input type="text" id="searchKeyword" placeholder="프로젝트명을 입력하세요 (2글자 이상)" />
        <button type="button" id="searchBtn">검색</button>
    </section>

    <div class="help-text">💡 프로젝트명을 클릭하면 해당 페이지로 바로 이동합니다.</div>
    <div style="display : flex; justify-content: space-between; flex-direction: row; width: 700px; align-items: center;">
    	<div class="result-count" id="resultCount"></div> <div id="refresh" class="result-count" style="cursor : pointer;">목록 새로고침</div>
    </div>   
	
    <section class="table-area">
        <table id="projectTable">
            <thead>
                <tr>
                    <th style="width: 15%;">순번</th>
                    <th>프로젝트명</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                
            </tbody>
        </table>
    </section>

    <div class="pagination" id="pagination"></div>
 
</body>
</html>
