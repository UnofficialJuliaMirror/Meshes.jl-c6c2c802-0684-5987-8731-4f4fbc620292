# http://en.wikipedia.org/wiki/Additive_Manufacturing_File_Format

function importAMF(io::IO)
    str = readall(io)
    xml = parse_string(str)
    xml_root = root(xml)
    object = find_element(xml_root, "object")
    mesh = find_element(object, "mesh")
    vertices = find_element(mesh, "vertices")
    volumes = get_elements_by_tagname(mesh, "volume")

    vts = Point3{Float64}[]

    for vertex in child_elements(vertices)
        coords = find_element(vertex, "coordinates")
        x = content(find_element(coords, "x"))
        y = content(find_element(coords, "y"))
        z = content(find_element(coords, "z"))
        push!(vts, Point3{Float64}(parse(Float64, x), parse(Float64, y), parse(Float64, z)))
    end

    meshes = Mesh{Point3{Float64}, Face{3,Int,0}}[]

    for volume in volumes
        fcs = Face{3,Int,0}[]
        triangles = get_elements_by_tagname(volume, "triangle")
        for triangle in triangles
            v1 = content(find_element(triangle, "v1"))
            v2 = content(find_element(triangle, "v2"))
            v3 = content(find_element(triangle, "v3"))
            push!(fcs, Face{3,Int,0}(parse(Int, v1), parse(Int, v2), parse(Int, v3)))
        end
        push!(meshes, Mesh(vts, fcs))
    end
    return meshes
end

